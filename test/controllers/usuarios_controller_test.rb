require "test_helper"

class UsuariosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get usuarios_index_url
    assert_response :success
  end

  test "should get show" do
    get usuarios_show_url
    assert_response :success
  end

  test "should get create" do
    get usuarios_create_url
    assert_response :success
  end

  test "should get update" do
    get usuarios_update_url
    assert_response :success
  end

  test "should get destroy" do
    get usuarios_destroy_url
    assert_response :success
  end
end
