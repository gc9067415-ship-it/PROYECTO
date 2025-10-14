module biblioteca::biblioteca {
    use std::string::String;
    use sui::vec_map::{VecMap, Self};

    public struct Biblioteca has key {
        id: UID,
        nombre: String,
        libros: VecMap<ISBN, Libro>,
    }

    public struct Libro has store, drop, copy {
        titulo: String,
        autor: String,
        publicacion: u16,
        disponible: bool,
    }

    public struct ISBN has store, drop, copy {
        value: u16
    }

    public fun crear_biblioteca(nombre: String, ctx: &mut TxContext) {
        let biblioteca = Biblioteca {
            id: object::new(ctx),
            nombre,
            libros: vec_map::empty(),
        };

        transfer::transfer(biblioteca, tx_context::sender(ctx));
    }

    public fun agregar_libro(titulo: String, autor: String, publicacion: u16, isbn: u16, biblioteca: &mut Biblioteca){
        let libro = Libro {
            titulo,
            autor,
            publicacion,
            disponible: true,
        };

        let isbn = ISBN { value: isbn };

        biblioteca.libros.insert(isbn, libro);
    }

    public fun eliminar_libro(isbn: u16, biblioteca: &mut Biblioteca){
        let isbn = ISBN { value: isbn };
        biblioteca.libros.remove(&isbn);
    }

    public fun actualizar_disponibilidad(isbn: u16, biblioteca: &mut Biblioteca){
        let isbn = ISBN { value: isbn };
        let libro = biblioteca.libros.get_mut(&isbn);
        libro.disponible = !libro.disponible;
    }

    public fun editar_titulo(isbn: u16, titulo: String, biblioteca: &mut Biblioteca){
        let isbn = ISBN { value: isbn };
        let libro = biblioteca.libros.get_mut(&isbn);
        libro.titulo = titulo;
    }

    public fun eliminar_biblioteca(biblioteca: Biblioteca) {
        let Biblioteca { id, libros: _, nombre: _ } = biblioteca;
        id.delete();
    }

}