using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.SqlClient;
/* 3 Write a program that retrieves from 
the Northwind database all product 
categories and the names of the products 
in each category. Can you do this with a 
single SQL query (with table join)?  */

class Program
{
    static void Main(string[] args)
    {
        var conn = new SqlConnection(
    @"Server=.\SQLExpress;Database=Northwnd;Integrated Security=true");

        conn.Open();

        using (conn)
        {
            var command = new SqlCommand(
@"SELECT CategoryName, ProductName 
FROM Categories JOIN Products
ON Categories.CategoryId = Products.CategoryId", conn);

            var reader = command.ExecuteReader();
            while (reader.Read())
            {
                Console.WriteLine("{0}, {1}", reader.GetString(0), reader.GetString(1));
            }

        }
    }
}
