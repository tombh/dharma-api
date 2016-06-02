# Methods needed by the API
module APIPHelpers
  def auth
    return if ENV['RACK_ENV'] != 'production' && ENV['RACK_ENV'] != 'test'
    begin
      api_key = Key.find_by api_key: params['api_key']
      key_status = api_key.status
    rescue Mongoid::Errors::DocumentNotFound
      key_status = 'not found'
    end
    return if key_status == 'active'
    status 401
    halt
  end

  def order_helper(default = '-date')
    # You can order by a field, by putting a '-' at the beginning for desc
    # and leaving it normal for asc
    @direction = 'asc'
    @order = params.fetch('order', default)
    if @order[0] == '-'
      @order.delete!('-')
      @direction = 'desc'
    end
    { @order.to_sym => @direction }
  end

  def pagination_helper
    @rpp = params['rpp'] ? params['rpp'].to_i : 25
    {
      per_page: @rpp,
      page: params['page']
    }
  end

  def rpp
    params.fetch('rpp', 25).to_i
  end

  def limit_helper
    rpp
  end

  def skip_helper
    rpp * (params.fetch('page', 1) - 1)
  end

  # I know it searches fields that aren't necessarily in the current model,
  # but mongo's pretty forgiving.
  def search_helper
    query = params['search']
    if query
      where = {
        '$or' => [
          { name: /#{query}/i },
          { bio: /#{query}/i },
          { title: /#{query}/i },
          { description: /#{query}/i },
          { permalink: /#{query}/i }
        ]
      }
    else
      where = {}
    end
    where
  end

  def respond(body)
    return 404 if (!body || body.empty?) && !body.is_a?(Array)

    answer = {}
    if body.is_a?(Mongoid::Criteria) && body.count > 0
      answer['metta'] = {}
      answer['metta']['total'] = @total
      answer['metta']['results_per_page'] = rpp
      answer['metta']['ordered_by'] = @order + ' ' + @direction
      answer['metta']['loving_kindness'] = true
    else
      body = [body]
    end

    answer['results'] = body
    answer = answer.to_json
    answer = "#{params['callback']}(#{answer})" if params['callback']
    answer
  end
end
