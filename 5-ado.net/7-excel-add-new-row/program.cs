using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.OleDb;
using System.Diagnostics;

/* 7 Implement appending new rows to the 
Excel file.  */

class Program
{
    static void Main(string[] args)
    {
        var cb = new OleDbConnectionStringBuilder();
        cb.DataSource = "scores.xlsx";
        cb.Provider = "Microsoft.ACE.OLEDB.12.0";
        cb.Add("Extended Properties", "Excel 12.0");

        using (var excelCon = new OleDbConnection(cb.ToString()))
        {
            excelCon.Open();

            OleDbCommand insertPlayer = new OleDbCommand(@"INSERT INTO [Sheet1$] (Name, Score) VALUES (@playerName, @playerScore)", excelCon);
            insertPlayer.Parameters.AddWithValue("@playerName", "Chuck Norris");
            insertPlayer.Parameters.AddWithValue("@playerScore", int.MaxValue);

            var inserted = insertPlayer.ExecuteNonQuery();

            Debug.Assert(inserted == 1);
        }
    }
}