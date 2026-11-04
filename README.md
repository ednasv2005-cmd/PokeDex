# 🔴 PokéDex UPIIT - Flutter

Aplicación tipo Pokédex desarrollada en Flutter que consume la [PokéAPI](https://pokeapi.co/).  
Proyecto de la **Práctica 7** - Programación de Dispositivos Móviles  
**Instituto Politécnico Nacional - UPIIT Campus Tlaxcala**

---

## 📱 Características

### Funcionalidades obligatorias
- ✅ Listado de Pokémon con **Infinite Scrolling** fluido (sin congelar la app)
- ✅ Tarjetas con imagen, nombre, número y tipos
- ✅ Detalle completo del Pokémon:
  - Artwork oficial + Sprite
  - Altura, peso, tipos y habilidades
  - Estadísticas base con barras visuales
  - Reproducción del grito (*cry*)
  - Cadena evolutiva
- ✅ Sistema de **Equipos**:
  - Crear, nombrar, editar y eliminar equipos
  - Máximo 6 Pokémon por equipo
  - Persistencia local (se mantienen al cerrar la app)
  - Vista de resumen de integrantes
- ✅ Búsqueda por nombre o número
- ✅ Filtros por tipo y generación

### Funcionalidades extra implementadas
- ❤️ Favoritos (con persistencia)
- ✨ Toggle Shiny / Normal
- 🌙 Modo claro / oscuro
- 🎲 Generador de equipo aleatorio
- 🎨 Colores dinámicos por tipo de Pokémon
- 🔄 Transiciones Hero entre listado y detalle
- 💀 Skeleton loaders
- 📱 Diseño moderno inspirado en la Pokédex clásica

---

## 🖼️ Capturas de pantalla

> *Reemplaza estas imágenes por capturas reales de tu app*

| Listado | Detalle | Equipos | Favoritos |
|---------|---------|---------|-----------|
| ![Listado](screenshots/listado.png) | ![Detalle](screenshots/detalle.png) | ![Equipos](screenshots/equipos.png) | ![Favoritos](screenshots/favoritos.png) |

| Búsqueda / Filtros | Modo Oscuro | Equipo Detalle |
|--------------------|-------------|----------------|
| ![Buscar](screenshots/buscar.png) | ![Dark](screenshots/dark.png) | ![Team](screenshots/team_detail.png) |

---

## 🛠️ Stack Tecnológico

| Tecnología              | Uso                              |
|-------------------------|----------------------------------|
| **Flutter**             | Framework principal              |
| **Riverpod**            | Gestión de estado                |
| **Dio**                 | Cliente HTTP                     |
| **Hive**                | Persistencia local (equipos y favoritos) |
| **Cached Network Image**| Caché de imágenes                |
| **AudioPlayers**        | Reproducción de cries            |
| **Google Fonts**        | Tipografía (Poppins)             |
| **Flutter Animate**     | Micro-animaciones                |
| **Shimmer**             | Skeleton loaders                 |

---

## 🏗️ Decisiones Técnicas

### Arquitectura
Se utilizó una arquitectura limpia separando responsabilidades:

- **Presentation** → Pantallas y widgets
- **Providers** → Lógica de estado (Riverpod)
- **Data** → Modelos, servicios de API y repositorios
- **Core** → Constantes, temas y utilidades

### Persistencia
- Los **equipos** y **favoritos** se guardan con **Hive** (rápido y ligero).
- Solo se almacenan los **IDs** de los Pokémon, no el objeto completo, para ahorrar espacio y mantener los datos actualizados.

### Infinite Scrolling (Reto técnico principal)

Este fue el punto más crítico. La solución implementada sigue estas estrategias:

1. **Paginación** con `limit=20` y `offset` (tamaño de página razonable).
2. El endpoint `/pokemon` solo trae `name` + `url`. Los detalles (tipos e imagen) se obtienen en **paralelo** usando `Future.wait`.
3. **Precarga anticipada**: se dispara la siguiente página cuando el usuario llega al **75%** del scroll.
4. Flag `isLoading` para evitar peticiones duplicadas al hacer scroll rápido.
5. Uso de `CachedNetworkImage` + sprites pequeños en el listado (artwork grande solo en el detalle).
6. Manejo de errores con botón de “Reintentar” sin perder lo ya cargado.
7. Virtualización nativa de Flutter (`GridView` / `CustomScrollView`).

Otras ideas evaluadas:
- Cachear el listado completo de nombres (~1300) localmente para búsqueda instantánea.
- Usar sprites desde GitHub directamente (URLs predecibles) para evitar peticiones extra en la lista.

---

## 🚀 Instalación y ejecución

### Requisitos
- Flutter 3.16 o superior
- Dart 3.2 o superior
- Android Studio / VS Code
- Emulador o dispositivo físico

### Pasos

```bash
# 1. Clonar el repositorio
git clone https://github.com/TU_USUARIO/pokedex_app.git
cd pokedex_app

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en dispositivo/emulador
flutter run
