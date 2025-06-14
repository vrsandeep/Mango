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
