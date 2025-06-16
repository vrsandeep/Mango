const changePage = (page) => {
  const url = `${location.protocol}//${location.host}${location.pathname}`;
  if (page < 1) {
    page = 1;
  }

  // preserve existing query parameters
  const queryParams = new URLSearchParams(window.location.search);
  queryParams.set('page', page);
  const newURL = `${url}?${queryParams.toString()}`;
  window.location.href = newURL;
};

const changePageSize = (pageSize) => {
  const url = `${location.protocol}//${location.host}${location.pathname}`;

  if (pageSize === null || pageSize < 1) {
    pageSize = 1000; // default page size
  }
  // preserve existing query parameters
  const queryParams = new URLSearchParams(window.location.search);
  queryParams.set('page_size', pageSize);
  // store page size in local storage
  localStorage.setItem('page_size', pageSize);

  const newURL = `${url}?${queryParams.toString()}`;
  window.location.href = newURL;
};

$(() => {
  // on page load, set the current page size selected attribute based on the query parameter page_size
  // otherwise default to 1000
  const queryParams = new URLSearchParams(window.location.search);
  const pageSize =
    queryParams.get('page_size') || localStorage.get('page_size') || 1000;
  $('#page-size-select').val(pageSize);
});
