import 'package:flutter_test/flutter_test.dart';
import 'package:divelogtest/utils/validators.dart';

void main() {
  group('Validators', () {
    test('required returns error string if empty or null', () {
      expect(Validators.required(null), 'Campo requerido');
      expect(Validators.required(''), 'Campo requerido');
      expect(Validators.required('   '), 'Campo requerido');
      expect(Validators.required('valid'), null);
    });

    test('email validates correctly', () {
      expect(Validators.email(null), 'Correo electrónico requerido');
      expect(Validators.email(''), 'Correo electrónico requerido');
      expect(Validators.email('invalid'), 'Ingresa un correo electrónico válido');
      expect(Validators.email('test@'), 'Ingresa un correo electrónico válido');
      expect(Validators.email('test@domain'), 'Ingresa un correo electrónico válido');
      expect(Validators.email('test@domain.com'), null);
    });

    test('password validates length', () {
      expect(Validators.password(null), 'Contraseña requerida');
      expect(Validators.password(''), 'Contraseña requerida');
      expect(Validators.password('123'), 'La contraseña debe tener al menos 6 caracteres');
      expect(Validators.password('123456'), null);
    });

    test('number validates numeric input', () {
      expect(Validators.number(null), null); // Optional unless combined with required
      expect(Validators.number(''), null);
      expect(Validators.number('abc'), 'Ingresa un número válido');
      expect(Validators.number('123'), null);
      expect(Validators.number('12.34'), null);
    });

    test('depth validates range and format', () {
      expect(Validators.depth('abc'), 'Ingresa una profundidad válida');
      expect(Validators.depth('-5'), 'La profundidad no puede ser negativa');
      expect(Validators.depth('350'), 'Profundidad excede límites normales');
      expect(Validators.depth('20'), null);
    });

    test('temperature validates range', () {
      expect(Validators.temperature('abc'), 'Ingresa una temperatura válida');
      expect(Validators.temperature('-5'), 'Temperatura fuera de rango normal');
      expect(Validators.temperature('60'), 'Temperatura fuera de rango normal');
      expect(Validators.temperature('25'), null);
    });
  });
}
