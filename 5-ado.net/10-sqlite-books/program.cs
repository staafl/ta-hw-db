using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.Common;
using System.Data.SQLite;
using System.IO;

/* 10 Re-implement the previous task with 
SQLite embedded DB (see 
http://sqlite.phxsoftware.com).  */

static class Program
{
    static void Main(string[] args) 
    {
        // http://system.data.sqlite.org/index.html/doc/trunk/www/downloads.wiki
        // i'm using http://system.data.sqlite.org/downloads/1.0.87.0/sqlite-netFx40-static-binary-bundle-x64-2010-1.0.87.0.zip
        // you'll need to download the x86 version and change the project build target to x86 if you're using a 32 bit
        // machine


        // http://www.connectionstrings.com/sqlite

        File.Delete("temp.db");
        SQLiteConnection.CreateFile(@".\temp.db");

        using (var conn = new SQLiteConnection(@"Data Source=.\temp.db"))
        {
            conn.Open();

            var create = new SQLiteCommand(
@"CREATE TABLE IF NOT EXISTS Books
(
    BookId INTEGER PRIMARY KEY AUTOINCREMENT,
    Title NVARCHAR(64),
    Author NVARCHAR(64),
    PublishDate DATE,
    ISBN CHAR(13)
)",
conn);

            create.ExecuteNonQuery();

            conn.AddBook("Lord of the Flies", "William Golding", DateTime.Today.AddYears(-60), "0123456789123");
            conn.AddBook("Of Mice and Men", "John Steinbeck", DateTime.Today.AddYears(-80), "1234567891234");
            conn.AddBook("Art Of War", "Sun Tzu", DateTime.Today.AddYears(-1500), "2345678912345");
            conn.AddBook("East of Eden", "John Steinbeck", DateTime.Today.AddYears(-80), "3456789123456");

            Console.WriteLine("All books:");
            Console.WriteLine();
            conn.ListAllBooks();
            Console.WriteLine();

            Console.WriteLine("By Steinbeck:");
            Console.WriteLine();
            conn.ListBooksByAuthor("John Steinbeck");
            Console.WriteLine();

        }
    }

    static void ListAllBooks(this DbConnection conn)
    {
        var command = conn.CreateCommand();
        command.CommandText = "SELECT * FROM Books";

        using (var reader = command.ExecuteReader())
        {
            while (reader.Read())
            {
                Console.WriteLine("{0}", reader.ShowReaderRow());
            }
        }
    }

    static string ShowReaderRow(this DbDataReader reader)
    {
        var array = new object[reader.FieldCount];
        reader.GetValues(array);
        return string.Join(", ", array);
    }

    static void ListBooksByAuthor(this SQLiteConnection conn, string author)
    {
        var command = conn.CreateCommand();
        command.CommandText = "SELECT * FROM Books WHERE Author = @Author";
        command.Parameters.Add(new SQLiteParameter("@Author", author));

        using (var reader = command.ExecuteReader())
        {
            while (reader.Read())
            {
                Console.WriteLine("{0}", reader.ShowReaderRow());
            }
        }
    }


    static void AddBook(this SQLiteConnection conn, string title, string author, DateTime publishDate, string isbn)
    {
        var command = conn.CreateCommand();
        command.CommandText = "INSERT INTO Books(Title, Author, PublishDate, ISBN) VALUES(@title, @author, @publishDate, @isbn)";
        command.Parameters.Add(new SQLiteParameter("@title", title));
        command.Parameters.Add(new SQLiteParameter("@title", title));
        command.Parameters.Add(new SQLiteParameter("@author", author));
        command.Parameters.Add(new SQLiteParameter("@publishDate", publishDate));
        command.Parameters.Add(new SQLiteParameter("@isbn", isbn));

        command.ExecuteNonQuery();
    }
}
