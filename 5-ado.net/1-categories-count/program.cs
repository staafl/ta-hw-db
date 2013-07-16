using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

/* 1 Write a program that retrieves from 
the Northwind sample database in MS SQL 
Server the number of  rows in the 
Categories table.  */

class Program
{
    static void Main(string[] args)
    {
        var conn = new SqlConnection(
            @"Server=.\SQLExpress;Database=Northwnd;Integrated Security=true");

        conn.Open();

        using (conn)
        {
            var command = new SqlCommand("SELECT COUNT(*) FROM Categories", conn);

            int rows = (int)command.ExecuteScalar();

            Console.WriteLine("Number of categories: {0}", rows);
        }
    }
}
