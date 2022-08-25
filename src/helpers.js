export const getPreviousDate = () => {
  const date = new Date();
  date.setDate(date.getDate() - 1);

  let day = date.getDate();
  let month = date.getMonth();
  const year = date.getFullYear();

  day = day < 10 ? "0" + day : day;
  month = month < 10 ? "0" + (month + 1) : month + 1;

  return `${year}-${month}-${day}`;
};

export const roundToTwoDecimalPlaces = (number) => {
  const roundOffset = 100;
  return Math.round(number * roundOffset) / roundOffset;
};
