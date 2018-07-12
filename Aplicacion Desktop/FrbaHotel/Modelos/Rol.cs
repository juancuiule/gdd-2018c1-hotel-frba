using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FrbaHotel.Modelos
{
    public class Rol
    {
        public int id_rol;
        public String nombre;

        public Rol(int id_rol, String nombre)
        {
            this.id_rol = id_rol;
            this.nombre = nombre;
        }

        public override string ToString()
        {
            return this.nombre;
        }
    }
}
