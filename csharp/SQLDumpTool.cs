using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Reflection;
using System.Diagnostics;
using System.Data;
using System.Data.SqlClient;
using System.Data.Common;
using CommandLine;
using System.Globalization;
using System.Threading;

// Usage
// SQLDumpTool -f "server=127.0.0.1,9000;database=XXX;uid=XXX;pwd=XXX" -t "Data source=localhost;Initial Catalog=YYY;Integrated Security=True;" -c 2000000

namespace MigrationTool
{
    public class Options
    {
        [Option('f', "from", Required = true, HelpText = "Source SQLServer connection string")]
        public string fromConnString { get; set; }

        [Option('t', "to", Required = true, HelpText = "Dest SQLServer connection string")]
        public string toConnString { get; set; }

        [Option('c', "count", Required = false, Default = 10000, HelpText = "Number of rows to copy")]
        public int count { get; set; }

        [Option('o', "overwrite", Required = false, Default = false, HelpText = "Overwrite existing rows")]
        public bool overwrite { get; set; }

        [Option('r', "reverse", Required = false, Default = false, HelpText = "Reverse table processing order")]
        public bool reverse { get; set; }

        [Option('s', "start", Required = false, Default = 0, HelpText = "Start at this index while looping tables")]
        public int start { get; set; }

        [Option('l', "tables", Required = false, HelpText = "List of tables to copy")]
        public IEnumerable<string> tables { get; set; }

        private HashSet<string> tableWanted = new HashSet<string>();

        public string Usage()
		{
			return "SQLDumpTool -f <connStr> -t <connStr> [-r] [-c <count>] [-l dbo.table1 dbo.table2] [-s 10]";
		}
    }

    public class TableItem
    {
        public string name        = null;
        public long   count       = 0;
        public string pkey_column = null;
        public string id_column   = null;

        public string sort_column
        {
            get 
            {
                if (this.pkey_column != null)
                {
                    return this.pkey_column;
                }

                return this.id_column;
            }
        }
    }

    public class SQLDumpTool
    {
        public string fromConnString, toConnString;

        public SQLDumpTool()
        {
        }

        public SQLDumpTool(string fromConnString, string toConnString)
        {
            this.fromConnString = fromConnString;
            this.toConnString   = toConnString;
        }

        public List<Dictionary<string, string>> RunQuery(string query)
        {
            var result = new List<Dictionary<string, string>>();

            using (SqlConnection conn = new SqlConnection(this.fromConnString))
            {
                conn.Open();

                using (SqlCommand command  = new SqlCommand(query, conn))
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Dictionary<string, string> data = new Dictionary<string, string>();
                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            string key = reader.GetName(i);
                            string val = reader.GetValue(i).ToString();

                            data[key] = val;
                        }

                        result.Add(data);
                    }
                }
            }

            return result;
        }

        public Dictionary<string, string> GetIdentityColumns()
        {
            var result = new Dictionary<string, string>();
            var data = this.RunQuery(@"
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMNPROPERTY(object_id(TABLE_SCHEMA+'.'+TABLE_NAME), COLUMN_NAME, 'IsIdentity') = 1");

            foreach(var row in data)
            {
                string full_name = "[" + row["TABLE_SCHEMA"] + "].[" + row["TABLE_NAME"] + "]";
                result[full_name] = row["COLUMN_NAME"];
            }

            return result;
        }

        public Dictionary<string, string> GetPrimaryKeyColumn()
        {
            var result = new Dictionary<string, string>();
            var data = this.RunQuery(@"
SELECT KU.table_schema TABLE_SCHEMA, KU.table_name TABLE_NAME, column_name COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
INNER JOIN
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KU
          ON TC.CONSTRAINT_TYPE = 'PRIMARY KEY' AND
             TC.CONSTRAINT_NAME = KU.CONSTRAINT_NAME
ORDER BY KU.TABLE_NAME, KU.ORDINAL_POSITION;");

            foreach(var row in data)
            {
                string full_name = "[" + row["TABLE_SCHEMA"] + "].[" + row["TABLE_NAME"] + "]";
                result[full_name] = row["COLUMN_NAME"];
            }
        	
            return result;
        }

        public void CopyData(TableItem item, int count)
        {
            SqlConnection conn1 = new SqlConnection(this.fromConnString);
            conn1.Open();

            SqlConnection conn2 = new SqlConnection(this.toConnString);
            conn2.Open();

            bool has_error = false;

            int offset = 0, perpage = 1000, total = 0, duplicates = 0;
            while (! has_error && total < count)
            {
                SqlCommand cmd1  = conn1.CreateCommand();
                cmd1.CommandText = String.Format(
                    "SELECT * FROM {0} ORDER BY {1} DESC OFFSET {2} ROWS FETCH NEXT {3} ROWS ONLY", 
                    item.name, item.sort_column,
                    offset, perpage);

                // 避免打印太多进度
                if (offset % 100000 == 0)
                {
                    Console.WriteLine("offset=" + offset + "; duplicates=" + duplicates);
                }

                // 连续 10K 重复内容，直接退出
                if (duplicates >= 10000)
                {
                    Console.WriteLine("Too many duplicates, finishing table early");
                    break;
                }

                SqlDataReader reader = cmd1.ExecuteReader();
                if (! reader.HasRows)
                {
                    Console.WriteLine("No more rows in " + item.name + ", total read " + offset);
                    break;
                }

                while (reader.Read())
                {
                    List<string> columns1 = new List<string>(), columns2 = new List<string>();
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        columns1.Add("[" + reader.GetName(i) + "]");
                        columns2.Add("@" + reader.GetName(i));
                    }

                    try
                    {
                        SqlCommand cmd2 = conn2.CreateCommand();
                        cmd2.CommandText = String.Format(
                            "INSERT INTO {0} ({1}) VALUES ({2})",
                            item.name,
                            String.Join(", ", columns1.ToArray()),
                            String.Join(", ", columns2.ToArray())
                        );

                        if (item.id_column != null)
                        {
                            cmd2.CommandText = 
                                "SET IDENTITY_INSERT " + item.name + " ON; " + 
                                cmd2.CommandText + 
                                "SET IDENTITY_INSERT " + item.name + " OFF; ";
                        }

                        for (int i = 0; i < columns2.Count; i++)
                        {
                            cmd2.Parameters.AddWithValue(columns2[i], reader.GetValue(i));
                        }

                        cmd2.ExecuteNonQuery();
                        duplicates = 0;
                    }
                    catch (SqlException se)
                    {
                        // duplicated key
                        if (se.Number == 2627)
                        {
                            duplicates ++;
                            continue;
                        }
                        
                        Console.WriteLine(se);
                        has_error = true;
                        break;
                    }

                    ++ total;
                }
                reader.Close();

                offset += perpage;
            }

            Console.WriteLine("Copied " + total + " rows in total, duplicates " + duplicates);
        }

        public List<TableItem> GetTableList()
        {
            var tables      = new List<TableItem>();            
            var key_columns = GetPrimaryKeyColumn();
            var id_columns  = GetIdentityColumns();

            var rows = this.RunQuery(@"
SELECT
    t.Name AS TABLE_NAME,
    s.NAME AS TABLE_SCHEMA,
    p.rows AS RowCounts
FROM
    sys.tables t
INNER JOIN
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
LEFT OUTER JOIN
    sys.schemas s ON t.schema_id = s.schema_id
WHERE
    t.NAME NOT LIKE 'dt%'
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255
    AND p.rows > 0
GROUP BY
    t.Name, s.Name, p.Rows
ORDER BY RowCounts DESC");

            foreach(var row in rows)
            {
                var name  = "[" + row["TABLE_SCHEMA"] + "].[" + row["TABLE_NAME"] + "]";
                var count = Convert.ToInt32(row["RowCounts"]);

                TableItem item = new TableItem {
                    name  = name,
                    count = count
                };

                if (id_columns.ContainsKey(name))
                {
                    item.id_column = id_columns[name];
                }

                if (key_columns.ContainsKey(name))
                {
                    item.pkey_column = key_columns[name];
                }

                tables.Add(item);
            }

            return tables;
        }

        public static void Main(string[] args)
        {
            CultureInfo ci = new CultureInfo("en-US");
            Thread.CurrentThread.CurrentCulture = ci;
            Thread.CurrentThread.CurrentUICulture = ci;

            // 这个需要 true font 字体
            // Console.OutputEncoding = System.Text.Encoding.UTF8;
            CommandLine.Parser.Default.ParseArguments<Options>(args)
                .WithParsed(RunOptions)
                .WithNotParsed(HandleParseError);
        }

        static void HandleParseError(IEnumerable<Error> errs)
        {
            // Console.WriteLine(errs);
        }

        static void RunOptions(Options options)
        {
            try
            {
                var tool        = new SQLDumpTool(options.fromConnString, options.toConnString);
                var tableItems  = tool.GetTableList();
                var tableWanted = new HashSet<string>();

                // 表过滤
                foreach (var table in options.tables)
                {
                    tableWanted.Add(table);
                }

                if (tableWanted.Count == 0)
                {
                    foreach (var table in tableItems)
                    {
                        tableWanted.Add(table.name);
                    }
                }

                // 打印数量
                Console.WriteLine("\nDumping row counts");
                foreach (var table in tableItems)
                {
                    Console.WriteLine(string.Format("{0,-50} {1}", table.name, table.count));
                }

                Console.WriteLine("\nDetermining sortable columns");
                foreach (var table in tableItems)
                {
                    if (table.pkey_column == null && table.id_column == null)
                    {
                        Console.WriteLine("Warning: " + table.name + " has no sortable column (row count: " + table.count + ")");
                        tableWanted.Remove(table.name);
                    }
                }

                if (options.reverse)
                {
                    tableItems.Reverse();
                }

                // 开始处理
                Console.WriteLine("\nPress any key to start");
                Console.ReadLine();

                int no = 0;
                foreach (var table in tableItems)
                {
                    no ++;
                    
                    if (no < options.start)
                    {
                        Console.WriteLine("Skipped table index " + no);
                        continue;
                    }
                    
                    if (! tableWanted.Contains(table.name))
                    {
                        continue;
                    }

                    Console.WriteLine(
                        String.Format("\n[ {0} / {1} ] Copying {2} sorted by {3}", 
                            no, tableWanted.Count, table.name, table.sort_column
                        ));
                    tool.CopyData(table, options.count);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
            }
        }
    }
}
