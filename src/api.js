import fetch from "node-fetch";

const getOptions = () => {
  const token = process.env.BEARER_TOKEN;

  const options = {
    method: "GET",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
  };

  return options;
};

export const fetchSTPData = async (prefix) => {
  const url = process.env.STP_DATA_URL + prefix;
  const options = getOptions();

  let body = {};

  try {
    const response = await fetch(url, options);
    body = await response.json();

    return body;
  } catch (err) {
    console.log(err.message);
    return body;
  }
};
