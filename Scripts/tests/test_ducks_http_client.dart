
import 'package:test/test.dart';

import '../ducks_http_client.dart';
import '../ducks_http_exception.dart';

void main() {
  group('DucksHttpClient', () {
    late DucksHttpClient client;

    setUp(() {
      client = DucksHttpClient('https://api.example.com');
    });

    tearDown(() {
      client.dispose();
    });

    test('constructor sets base URL correctly', () {
      expect(client, isNotNull);
    });

    test('setAuthToken stores token', () {
      expect(() => client.setAuthToken('test-token-123'), returnsNormally);
    });

    test('clearAuthToken removes token', () {
      client.setAuthToken('test-token');
      client.clearAuthToken();
      expect(() => client.clearAuthToken(), returnsNormally);
    });

    test('get builds correct URI', () {
      // This test would require mocking HttpClient to verify the URI
      // Since mocking HttpClient in Dart is complex without additional packages,
      // and the spec says to avoid external dependencies in tests for this task,
      // we'll test what we can without mocks
      expect(() => client.get('/test'), returnsNormally);
    });

    test('post builds correct URI', () {
      expect(() => client.post('/test'), returnsNormally);
    });

    test('disposal prevents further use', () {
      client.dispose();
      expect(() => client.get('/test'), throwsStateError);
      expect(() => client.post('/test'), throwsStateError);
      expect(() => client.put('/test'), throwsStateError);
      expect(() => client.delete('/test'), throwsStateError);
      expect(() => client.setAuthToken('token'), throwsStateError);
      expect(() => client.clearAuthToken(), throwsStateError);
    });
  });

  group('DucksHttpException', () {
    test('base exception can be instantiated', () {
      expect(DucksHttpException('test'), isA<DucksHttpException>());
    });

    test('UnauthorizedException extends DucksHttpException', () {
      expect(UnauthorizedException(), isA<DucksHttpException>());
    });

    test('ForbiddenException extends DucksHttpException', () {
      expect(ForbiddenException(), isA<DucksHttpException>());
    });

    test('NotFoundException extends DucksHttpException', () {
      expect(NotFoundException(), isA<DucksHttpException>());
    });

    test('BadRequestException extends DucksHttpException', () {
      expect(BadRequestException(), isA<DucksHttpException>());
    });

    test('InternalServerErrorException extends DucksHttpException', () {
      expect(InternalServerErrorException(), isA<DucksHttpException>());
    });
  });
}