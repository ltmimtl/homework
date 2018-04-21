require 'csv'

# load zips that we need to find the slcsp for
slcsp_zips = CSV.read('slcsp.csv', headers: true)['zipcode']

# load zip to rate area mappings for the zips that we care about
zips = CSV.foreach('zips.csv', headers: true)
          .select{ |z| slcsp_zips.include? z['zipcode'] }

# load the silver plans
silver_plans = CSV.foreach('plans.csv', headers: true)
                  .select{ |p| p['metal_level'] == 'Silver' }

CSV.open('slcsp.csv', 'w') do |slcsp_results|
  slcsp_results << %w[zipcode rate]

  slcsp_zips.each do |zip|

    # unique rate areas for this zip
    rate_areas = zips.select{ |x| x[0] == zip }.map{ |x| [x[1], x[4]] }.uniq

    slcsp_rate =
      if rate_areas.count == 1

        # map zip rate area to silver plans and return the second lowest
        silver_plans
            .select{ |x| x[1] == rate_areas[0][0] && x[4] == rate_areas[0][1] }
            .map{ |x| x[3] }
            .sort
            .uniq[1]
      else
        nil
      end
    slcsp_results << [zip, slcsp_rate]
  end
end
