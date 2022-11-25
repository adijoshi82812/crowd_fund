export const account_reducer = (state = null, action) => {
  switch (action.type) {
    case "update_account_reducer":
      return (state = action.payload);

    default:
      return state;
  }
};
