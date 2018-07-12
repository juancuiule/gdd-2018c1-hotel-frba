using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace FrbaHotel.Login
{
    public partial class ElegirRol : Form
    {
        public ElegirRol()
        {
            List<Modelos.Rol> roles = App.loggedUser.roles();
            InitializeComponent();
            roles.ForEach(delegate(Modelos.Rol rol)
            {
                this.comboBox1.Items.Add(rol);
            });
            this.comboBox1.SelectedItem = roles.First();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            App.rolActual = (Modelos.Rol) this.comboBox1.SelectedItem;
            // Ahora... chequear si tiene mas de un hotel
            Console.WriteLine(App.loggedUser.hoteles().Count);
            
        }
    }
}
