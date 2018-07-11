using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using System.Threading.Tasks;

namespace FrbaHotel {
    class DB_Hoteles {
        private static SqlConnection connection = new SQL_Connector().conection;

        public static Boolean loginUsuario(String username, String password) {
            return username == "prueba" && password == "1234";
        }

        // Por ahora solo calles...
        public static void mostrarHoteles()
        {
            SqlCommand cmd = new SqlCommand();
            SqlDataReader reader;

            cmd.CommandText = "select calle from hoteles";
            cmd.CommandType = CommandType.Text;
            cmd.Connection = connection;

            reader = cmd.ExecuteReader();
            if (reader.HasRows) {
                while (reader.Read()) {
                    Console.WriteLine("{0}", reader.GetString(0));
                }
            } else {
                Console.WriteLine("No se encontraron filas");
            }
            reader.Close();
        }
    }
}
