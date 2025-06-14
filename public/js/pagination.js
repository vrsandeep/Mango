$(() => {
  function changePage(page) {
    const url = `${location.protocol}//${location.host}${location.pathname}`;
    if (page < 1) {
      page = 1;
    }
    const newURL = `${url}?${$.param({
      page,
    })}`;
    window.location.href = newURL;
  }
});
