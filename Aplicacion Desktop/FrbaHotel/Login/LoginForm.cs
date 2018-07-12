using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace FrbaHotel.Login {
    public partial class LoginForm : Form {
        private String username;
        private String password;
        private int intentos;
        private String userALockear;

        public LoginForm() {
            InitializeComponent();
        }

        private void label1_Click(object sender, EventArgs e) {
            textBox1.Focus();
        }

        private void label2_Click(object sender, EventArgs e) {
            textBox2.Focus();
        }

        private void textBox1_TextChanged(object sender, EventArgs e) {
            this.username = textBox1.Text;
        }

        private void textBox2_TextChanged(object sender, EventArgs e) {
            this.password = textBox2.Text;
        }

        private void mostrarMensajeUsuarioInhabilitado(String usuario) {
            MessageBox.Show("Se inhabilito el usuario (" + usuario + ") por multiples intentos fallidos");
        }

        private void button1_Click(object sender, EventArgs e) {
            if (this.userALockear != this.username) { this.userALockear = this.username; this.intentos = 0; } // Actualizo nombre del user a lockear en caso de intentos fallidos
            if (this.userALockear == this.username && this.intentos >= 3) { this.mostrarMensajeUsuarioInhabilitado(this.username); return;  }

            Console.WriteLine("Intento de login para: " + this.username + " con password: " + this.password);
            Boolean success = DB_Hoteles.loginUsuario(this.username, this.password);
            Console.WriteLine("La combinacion fue: " + (success ? "correcta" : "incorrecta"));
            
            if (success) {
                this.Hide();
                MenuPrincipal.MenuPrincipal menu = new MenuPrincipal.MenuPrincipal("Empleado");
                menu.Show();
            }
            else {
                this.intentos++;
                if (this.intentos >= 3)
                {
                    DB_Hoteles.inhabilitarUsuario(this.username);
                    this.mostrarMensajeUsuarioInhabilitado(this.username);
                    return;
                }
                else
                {
                    MessageBox.Show("Combinacion incorrecta o usuario inexistente/inhabilitado");
                }
            }
            
        }
    }
}
