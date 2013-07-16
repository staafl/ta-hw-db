using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.SqlClient;
using System.IO;
using System.Text.RegularExpressions;
using System.Drawing;
using System.Drawing.Imaging;

/* 5 Write a program that retrieves the 
images for all categories in the 
Northwind database and stores them as 
JPG files in the file system.  */

class Program
{
    static void Main(string[] args)
    {
        var conn = new SqlConnection(
    @"Server=.\SQLExpress;Database=Northwnd;Integrated Security=true");

        conn.Open();

        using (conn)
        {
            var command = new SqlCommand("SELECT CategoryName, Picture FROM Categories", conn);

            var reader = command.ExecuteReader();
            while (reader.Read())
            {
                var name = reader.GetString(0);
                // remove invalid filename characters
                name = Regex.Replace(name, @"[\/*><:&""]", "_");

                const int OLE_METAFILEPICT_START_POSITION = 78;

                using (var fs = File.OpenWrite(name + ".jpg"))
                using (var stream = reader.GetStream(1))
                {
                    stream.Seek(OLE_METAFILEPICT_START_POSITION, SeekOrigin.Begin);
                    stream.CopyTo(fs);
                }
                 
            }

        }
    }
}
