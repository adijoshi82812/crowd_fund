export const donations_reducer = (state = 0, action) => {
  switch (action.type) {
    case "update_donations":
      return (state = action.payload);

    default:
      return state;
  }
};

export const total_funds_reducer = (state = 0, action) => {
  switch (action.type) {
    case "update_total_funds":
      return (state = action.payload);

    default:
      return state;
  }
};

export const completed_pools_reducer = (state = 0, action) => {
  switch (action.type) {
    case "update_completed_pools":
      return (state = action.payload);

    default:
      return state;
  }
};

export const approved_pools_reducer = (state = 0, action) => {
  switch (action.type) {
    case "update_funds_approved":
      return (state = action.payload);

    default:
      return state;
  }
};

export const is_user_reducer = (state = false, action) => {
  switch (action.type) {
    case "update_is_user":
      return (state = action.payload);

    default:
      return state;
  }
};
