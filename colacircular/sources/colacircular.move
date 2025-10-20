module colacircular::colacircular {
    public struct ColaCircular has drop {
    datos: vector<u64>,
        max: u64,
        frente: u64,
        final: u64,
    }
    
    /// Error cuando la cola está llena
    const E_COLA_LLENA: u64 = 1;
    
    /// Error cuando la cola está vacía
    const E_COLA_VACIA: u64 = 2;
    
    /// Crea una nueva cola circular con capacidad máxima
    public fun crear_cola(max: u64): ColaCircular {
        let mut datos = vector::empty<u64>();
        let mut i = 0;
        
        // Inicializar el vector con ceros
        while (i <= max) {
            vector::push_back(&mut datos, 0);
            i = i + 1;
        };
        
        ColaCircular {
            datos,
            max,
            frente: 0,
            final: 0,
        }
    }
    
    /// Verifica si la cola está llena
    public fun cola_llena(cola: &ColaCircular): bool {
        (cola.frente == 1 && cola.final == cola.max) || (cola.final + 1 == cola.frente)
    }
    
    /// Verifica si la cola está vacía
    public fun cola_vacia(cola: &ColaCircular): bool {
        cola.frente == 0
    }
    
    /// Inserta un elemento en la cola
    public fun insertar(cola: &mut ColaCircular, dato: u64) {
        // Verificar si la cola está llena
        assert!(!cola_llena(cola), E_COLA_LLENA);
        
        // Actualizar FINAL
        if (cola.final == cola.max) {
            cola.final = 1;
        } else {
            cola.final = cola.final + 1;
        };
        
        // Insertar el dato
        *vector::borrow_mut(&mut cola.datos, cola.final) = dato;
        
        // Si es el primer elemento, inicializar FRENTE
        if (cola.frente == 0) {
            cola.frente = 1;
        };
    }
    
    /// Quita un elemento de la cola y lo retorna
    public fun quitar(cola: &mut ColaCircular): u64 {
        // Verificar si la cola está vacía
        assert!(!cola_vacia(cola), E_COLA_VACIA);
        
        // Obtener el dato del frente
        let dato = *vector::borrow(&cola.datos, cola.frente);
        
        // Limpiar la posición
        *vector::borrow_mut(&mut cola.datos, cola.frente) = 0;
        
        // Verificar si la cola queda vacía
        if (cola.frente == cola.final) {
            cola.frente = 0;
            cola.final = 0;
        } else {
            // Actualizar FRENTE
            if (cola.frente == cola.max) {
                cola.frente = 1;
            } else {
                cola.frente = cola.frente + 1;
            };
        };
        
        dato
    }
    
    /// Obtiene todos los elementos de la cola sin quitarlos
    public fun obtener_elementos(cola: &ColaCircular): vector<u64> {
        let mut resultado = vector::empty<u64>();
        
        if (cola_vacia(cola)) {
            return resultado
        };
        
        let mut i = 1;
        while (i <= cola.max) {
            let valor = *vector::borrow(&cola.datos, i);
            if (valor != 0) {
                vector::push_back(&mut resultado, valor);
            };
            i = i + 1;
        };
        
        resultado
    }
    
    /// Obtiene el tamaño actual de la cola
    public fun tamano(cola: &ColaCircular): u64 {
        if (cola_vacia(cola)) {
            return 0
        };
        
        if (cola.final >= cola.frente) {
            cola.final - cola.frente + 1
        } else {
            cola.max - cola.frente + cola.final + 1
        }
    }
    
    /// Obtiene el valor del frente
    public fun get_frente(cola: &ColaCircular): u64 {
        cola.frente
    }
    
    /// Obtiene el valor del final
    public fun get_final(cola: &ColaCircular): u64 {
        cola.final
    }
    
    #[test]
    fun test_crear_cola() {
        let cola = crear_cola(10);
        assert!(cola_vacia(&cola), 0);
        assert!(cola.max == 10, 1);
        assert!(cola.frente == 0, 2);
        assert!(cola.final == 0, 3);
    }
    
    #[test]
    fun test_insertar_elemento() {
        let mut cola = crear_cola(10);
        insertar(&mut cola, 5);
        assert!(!cola_vacia(&cola), 0);
        assert!(cola.frente == 1, 1);
        assert!(cola.final == 1, 2);
        assert!(tamano(&cola) == 1, 3);
    }
    
    #[test]
    fun test_insertar_multiples_elementos() {
        let mut cola = crear_cola(10);
        insertar(&mut cola, 10);
        insertar(&mut cola, 20);
        insertar(&mut cola, 30);
        assert!(tamano(&cola) == 3, 0);
        assert!(cola.frente == 1, 1);
        assert!(cola.final == 3, 2);
    }
    
    #[test]
    fun test_quitar_elemento() {
        let mut cola = crear_cola(10);
        insertar(&mut cola, 100);
        insertar(&mut cola, 200);
        let dato = quitar(&mut cola);
        assert!(dato == 100, 0);
        assert!(tamano(&cola) == 1, 1);
        assert!(cola.frente == 2, 2);
    }
    
    #[test]
    fun test_cola_circular() {
        let mut cola = crear_cola(3);
        // Llenar la cola
        insertar(&mut cola, 1);
        insertar(&mut cola, 2);
        insertar(&mut cola, 3);
        
        // Quitar elementos
        let dato1 = quitar(&mut cola);
        assert!(dato1 == 1, 0);
        
        // Insertar más elementos (debe dar la vuelta)
        insertar(&mut cola, 4);
        assert!(cola.final == 1, 1);
    }
    
    #[test]
    fun test_vaciar_cola_completamente() {
        let mut cola = crear_cola(10);
        insertar(&mut cola, 5);
        insertar(&mut cola, 10);
        
        quitar(&mut cola);
        quitar(&mut cola);
        
        assert!(cola_vacia(&cola), 0);
        assert!(cola.frente == 0, 1);
        assert!(cola.final == 0, 2);
    }
    
    #[test]
    fun test_obtener_elementos() {
        let mut cola = crear_cola(10);
        insertar(&mut cola, 7);
        insertar(&mut cola, 14);
        insertar(&mut cola, 21);
        
        let elementos = obtener_elementos(&cola);
        assert!(vector::length(&elementos) == 3, 0);
    }
    
    #[test]
    #[expected_failure(abort_code = E_COLA_LLENA)]
    fun test_cola_llena_falla() {
        let mut cola = crear_cola(3);
        insertar(&mut cola, 1);
        insertar(&mut cola, 2);
        insertar(&mut cola, 3);
        // Este debe fallar porque la cola está llena
        insertar(&mut cola, 4);
    }
    
    #[test]
    #[expected_failure(abort_code = E_COLA_VACIA)]
    fun test_cola_vacia_falla() {
        let mut cola = crear_cola(10);
        // Intentar quitar de una cola vacía debe fallar
        quitar(&mut cola);
    }
    
    #[test]
    fun test_tamano_cola() {
        let mut cola = crear_cola(10);
        assert!(tamano(&cola) == 0, 0);
        
        insertar(&mut cola, 1);
        assert!(tamano(&cola) == 1, 1);
        
        insertar(&mut cola, 2);
        insertar(&mut cola, 3);
        assert!(tamano(&cola) == 3, 2);
        
        quitar(&mut cola);
        assert!(tamano(&cola) == 2, 3);
    }
}