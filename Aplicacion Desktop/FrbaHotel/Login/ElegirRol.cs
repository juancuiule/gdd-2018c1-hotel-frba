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
    }
}
