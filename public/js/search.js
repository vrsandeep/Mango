$(function () {
  /*// to perform local search:
  let filter = [];
  let result = [];
  $('.uk-card-title').each(function () {
    filter.push($(this).text());
  });
  $('.uk-search-input').keyup(function () {
    let input = $('.uk-search-input').val();

    let regex = new RegExp(input, 'i');
    if (input === '') {
      $('.item').each(function () {
        $(this).removeAttr('hidden');
      });
    } else {
      filter.forEach(function (text, i) {
        result[i] = text.match(regex);
      });
      $('.item').each(function (i) {
        if (result[i]) {
          $(this).removeAttr('hidden');
        } else {
          $(this).attr('hidden', '');
        }
      });
    }
  });*/

  // set the search input value from the query parameter
  const queryParams = new URLSearchParams(window.location.search);
  const searchValue = queryParams.get('search') || '';
  document.querySelector('.uk-search-input').value = searchValue;
  document
    .querySelector('.uk-search-input')
    .addEventListener('keydown', function (event) {
      if (event.key === 'Enter') {
        event.preventDefault(); // Prevent form submission
        let input = this.value;
        const url = `${location.protocol}//${location.host}${location.pathname}`;
        const queryParams = new URLSearchParams(window.location.search);
        queryParams.set('search', input);
        const newURL = `${url}?${queryParams.toString()}`;
        window.location.href = newURL;
      }
    });
});
