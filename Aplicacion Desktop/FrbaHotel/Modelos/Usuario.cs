using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FrbaHotel.Modelos
{
    public class Usuario
    {
        public int id_usuario;
        public String username;

        public Usuario(int id_usuario, String username)
        {
            this.id_usuario = id_usuario;
            this.username = username;
        }

        public List<Rol> roles()
        {
            return DB_Hoteles.getRolesPara(this.id_usuario);
        }
    }
}
