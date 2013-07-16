using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.SqlClient;
using System.Diagnostics;

/* 4 Write a method that adds a new product 
in the products table in the Northwind 
database. Use a parameterized SQL 
command.  */

class Program
{
    static void Main(string[] args)
    {
        var conn = new SqlConnection(
    @"Server=.\SQLExpress;Database=Northwnd;Integrated Security=true");

        conn.Open();

        using (conn)
        {
            var store = new SqlCommand(
@"INSERT Products(ProductName, SupplierId, CategoryId)
VALUES(@ProductName, @SupplierId, @CategoryId)", conn);
            store.Parameters.AddRange(
                new[]{
                    new SqlParameter("@ProductName", "Romsko Pivo"),
                    new SqlParameter("@SupplierId", 1),
                    new SqlParameter("@CategoryId", 1),

                });

            var inserted = store.ExecuteNonQuery();
            Debug.Assert(inserted == 1);
            var get = new SqlCommand("SELECT ProductName FROM Products WHERE ProductName = 'Romsko Pivo'", conn);

            var reader = get.ExecuteReader();
            while (reader.Read())
            {
                Console.WriteLine("{0}, {1}", reader.GetString(0));
            }

        }
    }
}
