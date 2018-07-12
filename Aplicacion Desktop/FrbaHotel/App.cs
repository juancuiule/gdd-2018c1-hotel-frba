using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace FrbaHotel {
    public partial class App : Form {
        public static Login.LoginForm loginForm;
        public static MenuPrincipal.MenuPrincipal menu;
        public static Modelos.Usuario loggedUser;

        public App() {
            InitializeComponent();
        }

        private void App_Load(object sender, EventArgs e) {}

        private void button_huesped(object sender, EventArgs e) {
            Console.WriteLine("Ingresa un Huesped");
            loggedUser = new Modelos.Usuario(2, "guest"); // user base de guest
            this.Hide();
            menu = new MenuPrincipal.MenuPrincipal();
            menu.Show();
        }

        private void button_empleado(object sender, EventArgs e) {
            Console.WriteLine("Ingresa un Empleado");
            this.Hide();
            loginForm = new FrbaHotel.Login.LoginForm();
            loginForm.Show();
        }
    }
}
