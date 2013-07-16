using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.SqlClient;

/* 2 Write a program that retrieves the 
name and description of all categories 
in the Northwind DB.  */

class Program
{
    static void Main(string[] args)
    {
        var conn = new SqlConnection(
    @"Server=.\SQLExpress;Database=Northwnd;Integrated Security=true");

        conn.Open();

        using (conn)
        {
            var command = new SqlCommand("SELECT CategoryName, Description FROM Categories", conn);

            var reader = command.ExecuteReader();
            while (reader.Read())
            {
                Console.WriteLine("{0}, {1}", reader.GetString(0), reader.GetString(1));
            }

        }
    }
}
