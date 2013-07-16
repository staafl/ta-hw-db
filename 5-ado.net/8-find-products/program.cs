using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
/* 8 Write a program that reads a string 
from the console and finds all products 
that contain this string. Ensure you 
handle correctly characters like ', %, 
", \ and _.  */

class Program
{
    static void Main(string[] args)
    {
        Console.WriteLine("Enter pattern to search for:");
        var pattern = Console.ReadLine();

        using (var conn = new SqlConnection(
    @"Server=.\SQLExpress;Database=Northwnd;Integrated Security=true"))
        {
            conn.Open();

            var command = new SqlCommand("SELECT ProductName FROM Products WHERE ProductName LIKE @Pattern", conn);

            // http://stackoverflow.com/questions/7191449/how-do-i-escape-a-percentage-sign-in-t-sql

            pattern = Regex.Replace(pattern, @"[%_\/']", "[$1]");
            command.Parameters.AddWithValue("@Pattern", "%" + pattern + "%");

            var reader = command.ExecuteReader();

            while (reader.Read())
            {
                Console.WriteLine("{0}", reader.GetString(0));
            }

        }
    }
}
