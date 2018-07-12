using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FrbaHotel.Modelos
{
    public class Hotel
    {
        public int id_hotel;
        public String calle;
        public String ciudad;
        public int nro_calle;
        public int recarga_estrellas;
        public int cant_estrellas;
        public int habilitado;
        public String nombre;
        public DateTime fecha_creacion;
        public String mail;
        public String telefono;
        public String pais;

        public Hotel(int id_hotel, String calle, String ciudad, int nro_calle, int recarga_estrellas, int cant_estrellas, int habilitado, String nombre, DateTime fecha_creacion, String mail, String telefono, String pais)
        {
            this.id_hotel = id_hotel;
            this.calle = calle;
            this.ciudad = ciudad;
            this.nro_calle = nro_calle;
            this.recarga_estrellas = recarga_estrellas;
            this.cant_estrellas = cant_estrellas;
            this.habilitado = habilitado;
            this.nombre = nombre;
            this.fecha_creacion = fecha_creacion;
            this.mail = mail;
            this.telefono = telefono;
            this.pais = pais;
        }
    }
}
