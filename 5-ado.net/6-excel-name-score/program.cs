using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.OleDb;

/* 6 Create an Excel file with 2 columns: 
name and score:Write a program that 
reads your MS Excel file through the OLE 
DB data provider and displays the name 
and score row by row.  */

class Program
{
    static void Main(string[] args)
    {
        // I don't have Excel so I can't test this.

        var cb = new OleDbConnectionStringBuilder();
        cb.DataSource = "scores.xlsx";
        cb.Provider = "Microsoft.ACE.OLEDB.12.0";
        cb.Add("Extended Properties", "Excel 12.0");

        using (var excelCon = new OleDbConnection(cb.ToString()))
        {
            excelCon.Open();

            var command = new OleDbCommand(@"SELECT @playerName, @playerScore FROM [Sheet1$]", excelCon);

            var reader = command.ExecuteReader();

            while (reader.Read())
                Console.WriteLine("{0} {1}", reader.GetString(0), reader.GetInt32(1));
        }
    }
}
