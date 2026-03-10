import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/registro_page.dart';
import '../pages/perfil_page.dart';
import '../pages/crear_album_page.dart';
import '../pages/unirse_album_page.dart';
/*import 'package:flutter_application_1/pages/add_page.dart';
import 'package:flutter_application_1/pages/cart_page.dart';
import 'package:flutter_application_1/pages/edit_page.dart';
import 'package:flutter_application_1/pages/init_page.dart';
import 'package:flutter_application_1/pages/options_page.dart';*/

class Routes {
  static final routes = <String, WidgetBuilder>{
    '/': (context) => const IniciarSesionPage(),
    'registroPage': (BuildContext context) => const RegistroPage(),
    'perfilPage': (BuildContext context) => const PerfilPage(),
    'crearAlbumPage': (context) => const CrearAlbumPage(),
    'unirseAlbumPage': (context) => const UnirseAlbumPage(),
    /*'/add_page': (context) => const AddPage(),
    '/options_page': (context) => OptionsPage(),
    '/cart_page': (context) => const MyCart(),
    '/init_page': (context) => const InitPage(
          title: '',
        ),
    '/products_page': (context) => ProductListPage(),*/
  };
}
