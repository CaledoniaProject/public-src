#!/usr/bin/env python3

import sys
import csv
import mailparser

if __name__ == '__main__':
    with open('ex.csv', 'w') as csvfile:
        spamwriter = csv.writer(csvfile, delimiter=',', quotechar='"')
        spamwriter.writerow(['发件人', '收件人', '主题', '附件'])

        for file in sys.argv[1:]:
            mail = mailparser.parse_from_file(file)
            files = []

            for attachment in mail.attachments:
                files.append(attachment['filename'])

            spamwriter.writerow([
                mail.from_[0][0] + ' <' + mail.from_[0][1] + '>', 
                mail.to[0][len(mail.to[0]) - 1] if mail.to else '', 
                mail.subject, 
                ','.join(files)])

