defmodule Astarte.Housekeeping.APIWeb.AuthTest do
  use Astarte.Housekeeping.APIWeb.ConnCase

  alias Astarte.Housekeeping.API.JWTTestHelper

  @request_path "/v1/realms"
  @valid_auth_path "^realms$"
  @non_exact_match_valid_auth_path "^rea.*$"
  @non_matching_auth_path "^stats.*$"

  @expected_data []

  require Logger

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "JWT" do
    test "no token returns 401", %{conn: conn} do
      conn = get(conn, @request_path)
      assert json_response(conn, 401)["errors"]["detail"] == "Unauthorized"
    end

    test "all access token returns the data", %{conn: conn} do
      conn =
        put_req_header(conn, "authorization", "bearer #{JWTTestHelper.gen_jwt_all_access_token()}")
        |> get(@request_path)

      assert json_response(conn, 200) == @expected_data
    end

    test "valid token returns the data", %{conn: conn} do
      conn =
        put_req_header(conn, "authorization", "bearer #{JWTTestHelper.gen_jwt_token(["^GET$::#{@valid_auth_path}"])}")
        |> get(@request_path)

      assert json_response(conn, 200) == @expected_data
    end

    test "token for another path returns 403", %{conn: conn} do
      conn =
        put_req_header(conn, "authorization", "bearer #{JWTTestHelper.gen_jwt_token(["^GET$::#{@non_matching_auth_path}"])}")
        |> get(@request_path)

      assert json_response(conn, 403)["errors"]["detail"] == "Forbidden"
    end

    test "token for both paths returns the data", %{conn: conn} do

      conn =
        put_req_header(conn, "authorization", "bearer #{JWTTestHelper.gen_jwt_token(["^GET$::#{@non_matching_auth_path}", "^GET$::#{@valid_auth_path}"])}")
        |> get(@request_path)

      assert json_response(conn, 200) == @expected_data
    end

    test "token for another method returns 403", %{conn: conn} do
      conn =
        put_req_header(conn, "authorization", "bearer #{JWTTestHelper.gen_jwt_token(["^POST$::#{@valid_auth_path}"])}")
        |> get(@request_path)

      assert json_response(conn, 403)["errors"]["detail"] == "Forbidden"
    end
    
    test "token for both methods returns the data", %{conn: conn} do
      conn =
        put_req_header(conn, "authorization", "bearer #{JWTTestHelper.gen_jwt_token(["^POST$::#{@valid_auth_path}", "^GET$::#{@valid_auth_path}"])}")
        |> get(@request_path)

      assert json_response(conn, 200) == @expected_data
    end

    test "token with generic matching regexp returns the data", %{conn: conn} do
      conn =
        put_req_header(conn, "authorization", "bearer #{JWTTestHelper.gen_jwt_token(["^.*$::#{@non_exact_match_valid_auth_path}"])}")
        |> get(@request_path)

      assert json_response(conn, 200) == @expected_data
    end
  end
end