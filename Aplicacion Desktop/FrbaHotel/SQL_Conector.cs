using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;
using System.Data.SqlClient;
using System.Data;
using System.Drawing;
using System.Configuration;
using System.Windows.Forms;

namespace FrbaHotel {
    class SQL_Connector {
        public SqlConnection conection;

        public SQL_Connector() {
            try {
                conection = new SqlConnection(@"Data source=localhost\SQLSERVER2012; Initial Catalog=GD1C2018;user=gdHotel2018;password=gd2018");
                conection.Open();
                Console.WriteLine("Conexión a la BD correcta");
            } catch (Exception e) {
                MessageBox.Show(e.ToString());
                MessageBox.Show("Hubo un error al conectarse con la BD");
            }
        }
    }
}
