import fetch from "../util/fetch-fill";
import URI from "urijs";

// /records endpoint
window.path = "http://localhost:3000/records";

// Your retrieve function plus any additional functions go here ...
function retrieve(options = { page: 1, colors: [] }) {
  const per_page = 10;
  const primaries = ['red', 'blue', 'yellow'];
  options.page = options.page || 1;
  options.colors = options.colors || [];

  // build URL w/ hash and append colors
  var url = URI(window.path).query({
    limit: per_page + 1,
    offset: (options.page * per_page) - per_page
  }) + options.colors.map(color => '&color[]=' + color).join('');

  return fetch(url)
    .then(function(response) {
      return response.json().then(function(data) {

        // retrieved 1 more to see if there's a next page
        var paged_data = data.slice(0, per_page);

        return {
          ids: paged_data.map(d => d.id),
          open: paged_data
          .filter(d => d.disposition == 'open')
          .map(function(d) {
            d.isPrimary = primaries.includes(d.color)
            return d;
          }),
          closedPrimaryCount: paged_data.reduce(function(total, current) {
            if (current.disposition == 'closed' && primaries.includes(current.color)) {
              return total + 1;
            } else {
              return total;
            }
          }, 0),
          previousPage: (options.page == 1 ? null : options.page - 1),
          nextPage: function(data) {
            if (data.length > per_page) {
              return options.page + 1;
            } else {
              return null;
            }
          }(data)
        };
      });
    })
    .catch(error => console.log(error));
};

export default retrieve;
