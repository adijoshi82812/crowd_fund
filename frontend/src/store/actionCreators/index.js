import { ethereum, Contract } from "../../web3";

const getAccount = async () => {
  var account = null;
  try {
    const accounts = await ethereum.request({ method: "eth_requestAccounts" });
    account = accounts[0];
  } catch (err) {
    console.log(err);
  }

  return account;
};

const get_data = async (index) => {
  switch (index) {
    case 1:
      let donations = await Contract.methods.donations().call();
      donations = donations / Math.pow(10, 18);
      return donations;

    case 2:
      let funds_approved = await Contract.methods.approved_pools().call();
      return funds_approved;

    case 3:
      let total_funds = await Contract.methods.total_funds_raised().call();
      return total_funds;

    case 4:
      let completed_funds = await Contract.methods.completed_pools().call();
      return completed_funds;

    default:
      return false;
  }
};

export const update_account = () => {
  return async (dispatch) => {
    dispatch({
      type: "update_account_reducer",
      payload: await getAccount(),
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
