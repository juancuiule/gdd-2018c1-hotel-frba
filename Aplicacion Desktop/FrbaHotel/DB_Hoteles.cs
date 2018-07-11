using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace FrbaHotel {
    class DB_Hoteles {
        private static SqlConnection connection = new SQL_Connector().conection;

        public static Boolean loginUsuario(String username, String password) {
            return username == "prueba" && password == "1234";
        }
    }
}
