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
        
        // USER

        public static Modelos.Usuario loginUsuario(String username, String password) {
            DB_Hoteles.setCmd("select id_usuario from usuarios where username='" + username + "' and password = hashbytes('SHA2_256', '" + password + "')");
            reader = cmd.ExecuteReader();
            if (reader.HasRows)
            {
                reader.Read();
                int id_usuario = reader.GetInt32(0);
                Console.WriteLine("{0} - {1}", id_usuario, username);
                reader.Close();
                
                return new Modelos.Usuario(id_usuario, username);
            }
            reader.Close();
            return null;
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

        public static List<Modelos.Rol> getRolesPara(int id_usuario)
        {
            DB_Hoteles.setCmd("select distinct r.id_rol, r.nombre, r.estado from roles_por_usuario ru join roles r on (ru.id_rol = r.id_rol) where r.estado = 1 and id_usuario ='" + id_usuario + "'");
            reader = cmd.ExecuteReader();
            List<Modelos.Rol> roles = new List<Modelos.Rol>();
            if (reader.HasRows)
            {
                while (reader.Read())
                {
                    int id_rol = reader.GetInt32(0);
                    String nombre = reader.GetString(1);
                    roles.Add(new Modelos.Rol(id_rol, nombre));
                }
            }
            reader.Close();
            return roles;
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
