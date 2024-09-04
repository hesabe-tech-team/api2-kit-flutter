import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_interface.g.dart';

@RestApi()
abstract class ApiInterface {
  factory ApiInterface(Dio dio) = _ApiInterface;

  @POST("/checkout")
  Future<String> hesabePay(
    @Header("accessCode") String accessToken,
    @Query("data") String data,
  );
}
