export const pool_id_reducer = (state = 0, action) => {
  switch (action.type) {
    case "update_pool_id_reducer":
      return (state = action.payload);

    default:
      return state;
  }
};
