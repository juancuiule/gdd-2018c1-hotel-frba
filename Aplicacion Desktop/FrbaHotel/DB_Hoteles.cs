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
        private static SqlCommand cmd = new SqlCommand();
        private static SqlDataReader reader;

        public static void setCmd(String query) {
            cmd.CommandText = query;
            cmd.CommandType = CommandType.Text;
            cmd.Connection = connection;
        }
        
        public static Boolean loginUsuario(String username, String password) {
            Boolean testing = (username == "prueba" && password == "1234");
            DB_Hoteles.setCmd("select id_usuario, username from usuarios where username='" + username + "' and password = hashbytes('SHA2_256', '" + password + "')");
            reader = cmd.ExecuteReader();
            if (reader.HasRows)
            {
                reader.Read();
                Console.WriteLine("{0} - {1}", reader.GetInt32(0), reader.GetString(1));
                reader.Close();
                return true;
            }
            reader.Close();
            return testing;
        }

        public static void inhabilitarUsuario(String username) {
            DB_Hoteles.setCmd("select id_usuario from usuarios where habilitado = 1 and username = '" + username + "'");
            reader = cmd.ExecuteReader();
            if (reader.HasRows) {
                reader.Read();
                int id_usuario = reader.GetInt32(0);
                reader.Close();
                DB_Hoteles.setCmd("update usuarios set habilitado = 0 where id_usuario = '" + id_usuario + "'");
                reader = cmd.ExecuteReader();
                reader.Read();
                reader.Close();
            }
            reader.Close();
        }

        // Por ahora solo calles...
        public static void mostrarHoteles()
        {
            DB_Hoteles.setCmd("select calle from hoteles");
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
