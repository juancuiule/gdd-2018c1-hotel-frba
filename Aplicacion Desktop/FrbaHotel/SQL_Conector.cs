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
                // conection = new SqlConnection(@"Data source=.\SQLEXPRESS; Initial Catalog=GD1C2018;");
                // conection.Open();
            } catch (Exception e) {
                MessageBox.Show(e.ToString());
                MessageBox.Show("Hubo un error al conectarse con la BD");
            }
        }
    }
}
