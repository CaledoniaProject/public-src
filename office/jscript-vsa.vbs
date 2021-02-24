' 来自
' https://twitter.com/PhilipTsukerman/status/1035157960308211712
'
' 工具 -> 引用，添加
' Microsoft_Vsa
' mscorlib.dll
' 

Sub test()

	Dim vsa
	Dim vsa2 As IVsaEngine
	Dim author
	Dim eng As mscorlib.Object
	Dim Items As IUnknown
	Dim Text As IVsaCodeItem

	Set vsa = CreateObject("Microsoft.Jscript.VSA.VSAEngine")
	Set vsa2 = vsa
	Set author = CreateObject("Microsoft.Jscript.JSAuthor")
	Set eng = author.GetCodeSense()
	vsa.InitVsaEngine "jsc:\\test", eng
	vsa2.Items.CreateItem "Source", 2, 0
	vsa2.Items.CreateItem "System.Windows.Forms", 0, 0
	Set Text = vsa2.Items.Item("Source")
	Text.AppendSourceText "import System.Windows.Forms; System.Windows.Forms.MessageBox.Show(""Test"", ""Test"", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);"
	vsa.Compile
	vsa.RunEmpty

End Sub

