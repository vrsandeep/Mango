$(() => {
  $('#sort-select').change(() => {
    const sort = $('#sort-select').find(':selected').attr('id');
    const ary = sort.split('-');
    const by = ary[0];
    const dir = ary[1];

    const url = `${location.protocol}//${location.host}${location.pathname}`;

    const queryParams = new URLSearchParams(window.location.search);
    queryParams.set('sort', by);
    queryParams.set('ascend', dir === 'up' ? 1 : 0);
    const newURL = `${url}?${queryParams.toString()}`;
    window.location.href = newURL;
  });
});
