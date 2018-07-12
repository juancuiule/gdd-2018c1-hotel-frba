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
            Modelos.Usuario userSuccess = DB_Hoteles.loginUsuario(this.username, this.password);
            Console.WriteLine("La combinacion fue: " + (userSuccess != null ? "correcta" : "incorrecta"));
            
            if (userSuccess != null) {
                App.loggedUser = userSuccess;
                int cantRoles = App.loggedUser.roles().Count;
                if (cantRoles == 0)
                {
                    MessageBox.Show("Este usuario no tiene roles asignados, proba con otro");
                    textBox1.ResetText();
                    textBox2.ResetText();
                }
                else if (cantRoles == 1)
                {
                    // Sigue de una
                    this.Hide();
                    MenuPrincipal.MenuPrincipal menu = new MenuPrincipal.MenuPrincipal();
                    menu.Show();
                }
                else if (cantRoles > 1)
                {
                    // Tiene que elegir un rol
                }
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
