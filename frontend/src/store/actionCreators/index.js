import { ethereum, Contract } from "../../web3";

const get_data = async (index) => {
  switch (index) {
    case 1:
      let donations = await Contract.methods.donations().call();
      donations = Math.round(donations / Math.pow(10, 18));
      return donations;

    case 2:
      let funds_approved = await Contract.methods.funds_approved().call();
      return funds_approved;

    case 3:
      let total_funds = await Contract.methods.total_requests().call();
      return total_funds;

    case 4:
      let completed_funds = await Contract.methods.funded_pools().call();
      return completed_funds;

    case 5:
      let taccount = await get_data(6);
      let result = await Contract.methods.users(taccount).call();
      return result;

    case 6:
      var account = null;
      try {
        const accounts = await ethereum.request({
          method: "eth_requestAccounts",
        });
        account = accounts[0];
      } catch (err) {
        console.log(err);
      }
      return account;

    default:
      return false;
  }
};

export const update_account = () => {
  return async (dispatch) => {
    dispatch({
      type: "update_account_reducer",
      payload: await get_data(6),
    });
  };
};

export const update_donations = () => {
  return async (dispatch) => {
    dispatch({
      type: "update_donations",
      payload: await get_data(1),
    });
  };
};

export const update_funds_approved = () => {
  return async (dispatch) => {
    dispatch({
      type: "update_funds_approved",
      payload: await get_data(2),
    });
  };
};

export const update_total_funds = () => {
  return async (dispatch) => {
    dispatch({
      type: "update_total_funds",
      payload: await get_data(3),
    });
  };
};

export const update_completed_pools = () => {
  return async (dispatch) => {
    dispatch({
      type: "update_completed_pools",
      payload: await get_data(4),
    });
  };
};

export const update_is_user = () => {
  return async (dispatch) => {
    dispatch({
      type: "update_is_user",
      payload: await get_data(5),
    });
  };
};
