module BasicRecognitionTests
  def test_path
    get "/foo"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "foo", :action => "index" }, env["rack.routing_args"])

    post "/foo"
    assert env
    assert_equal("POST", env["REQUEST_METHOD"])
    assert_equal({ :controller => "foo", :action => "index" }, env["rack.routing_args"])

    put "/foo"
    assert env
    assert_equal("PUT", env["REQUEST_METHOD"])
    assert_equal({ :controller => "foo", :action => "index" }, env["rack.routing_args"])

    delete "/foo"
    assert env
    assert_equal("DELETE", env["REQUEST_METHOD"])
    assert_equal({ :controller => "foo", :action => "index" }, env["rack.routing_args"])
  end

  def test_nested_path
    get "/foo/bar"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "foo_bar", :action => "index" }, env["rack.routing_args"])
  end

  def test_path_mapped_with_leading_slash
    get "/baz"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "baz", :action => "index" }, env["rack.routing_args"])
  end

  def test_path_does_get_shadowed
    get "/people"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "people", :action => "index" }, env["rack.routing_args"])

    get "/people/new"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "people", :action => "new" }, env["rack.routing_args"])
  end

  def test_root_path
    get "/"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "homepage" }, env["rack.routing_args"])
  end

  def test_extracts_parameters
    get "/foo/bar/1"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "foo", :action => "bar", :id => "1" },
      env["rack.routing_args"])

    get "/foo/bar/1.xml"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "foo", :action => "bar", :id => "1", :format => "xml" },
      env["rack.routing_args"])
  end

  def test_extracts_id
    get "/people/1"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "people", :action => "show", :id => "1" }, env["rack.routing_args"])

    put "/people/1"
    assert env
    assert_equal("PUT", env["REQUEST_METHOD"])
    assert_equal({ :controller => "people", :action => "update", :id => "1" }, env["rack.routing_args"])

    delete "/people/1"
    assert env
    assert_equal("DELETE", env["REQUEST_METHOD"])
    assert_equal({ :controller => "people", :action => "destroy", :id => "1" }, env["rack.routing_args"])

    get "/people/2/edit"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "people", :action => "edit", :id => "2" }, env["rack.routing_args"])
  end

  def test_requirements
    get "/geocode/60614"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "geocode", :action => "show", :postalcode => "60614" }, env["rack.routing_args"])

    get "/geocode2/60614"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "geocode", :action => "show", :postalcode => "60614" }, env["rack.routing_args"])
  end

  def test_path_with_globbing
    get "/files/images/photo.jpg"
    assert env

    # TODO
    # assert_equal({:files => ["images", "photo.jpg"]}, env["rack.routing_args"])
    assert_equal({ :controller => "files", :action => "index", :files => "images/photo.jpg" }, env["rack.routing_args"])
  end

  def test_with_controller_scope
    get "/global/index"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "global", :action => "index" }, env["rack.routing_args"])

    get "/global/show"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "global", :action => "show" }, env["rack.routing_args"])

    get "/global/export"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "global", :action => "export" }, env["rack.routing_args"])

    get "/global/hide_notice"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "global", :action => "hide_notice" }, env["rack.routing_args"])

    get "/export/1/foo"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "global", :action => "export", :id => "1", :file => "foo" }, env["rack.routing_args"])
  end

  def test_another_with_controller_scope
    get "/login"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "sessions", :action => "new" }, env["rack.routing_args"])

    post "/login"
    assert env
    assert_equal("POST", env["REQUEST_METHOD"])
    assert_equal({ :controller => "sessions", :action => "create" }, env["rack.routing_args"])

    get "/logout"
    assert_nil env

    delete "/logout"
    assert env
    assert_equal("DELETE", env["REQUEST_METHOD"])
    assert_equal({ :controller => "sessions", :action => "destroy" }, env["rack.routing_args"])
  end

  def test_optional_route
    get "/optional/index"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "optional", :action => "index" }, env["rack.routing_args"])

    get "/optional/index.xml"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "optional", :action => "index", :format => "xml" }, env["rack.routing_args"])
  end

  def test_namespaced_resources
    get "/account/subscription"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "account/subscription", :action => "index" }, env["rack.routing_args"])

    get "/account/credit"
    assert env
    assert_equal("GET", env["REQUEST_METHOD"])
    assert_equal({ :controller => "account/credit", :action => "index" }, env["rack.routing_args"])
  end

  def test_not_found
    get "/admin/widgets/show/random"
    assert_nil env
  end
end
