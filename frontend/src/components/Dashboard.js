import { useEffect, useState } from "react";
import { useSelector, useDispatch } from "react-redux";
import { Contract } from "../web3";
import { bindActionCreators } from "redux";
import { actionCreators } from "../store";

export const Dashboard = () => {
  const donations = useSelector((state) => state.donations);
  const funds_approved = useSelector((state) => state.approved_pools);
  const total_funds = useSelector((state) => state.total_funds);
  const completed_funds = useSelector((state) => state.completed_pools);
  const dispatch = useDispatch();
  const { update_pool_id } = bindActionCreators(actionCreators, dispatch);

  const [data, setData] = useState([]);

  const get_list = async () => {
    try {
      const pools_count = await Contract.methods.pools_count().call();
      const temp_data_arr = [];
      if (pools_count !== 0) {
        for (let i = pools_count - 1; i >= 0; i--) {
          const temp_data = await Contract.methods.pools(i).call();
          temp_data_arr.push(temp_data);
        }
      }
      setData(temp_data_arr);
    } catch (err) {
      console.log(err);
    }
  };

  const display_list = data.map((data) => (
    <tr>
      <td>{data.name}</td>
      <td>
        {data.admin.slice(0, 5).toLowerCase()}...
        {data.admin.slice(38).toLowerCase()}&nbsp;
        <i
          className="ion ion-clipboard"
          style={{ cursor: "pointer" }}
          title="Copy to clipboard"
          onClick={(e) => {
            e.preventDefault();
            navigator.clipboard.writeText(data.admin);
          }}
        ></i>
      </td>
      <td>{data.is_approved ? "active" : "inactive"}</td>
      <td>{data.funds_asked / Math.pow(10, 18)} $ETH</td>
      <td>{data.funds_received / Math.pow(10, 18)} $ETH</td>
      <td>
        {data.is_approved && !data.isFilled && data.is_valid ? (
          <button
            className="btn btn-block btn-outline-success btn-xs"
            data-toggle="modal"
            data-target="#invest-modal"
            onClick={(e) => {
              e.preventDefault();
              update_pool_id(data.id);
            }}
          >
            Invest
          </button>
        ) : data.is_valid ? (
          <button className="btn btn-block btn-outline-primary btn-xs disabled">
            Invest
          </button>
        ) : (
          <button className="btn btn-block btn-outline-danger btn-xs disabled">
            Invest
          </button>
        )}
      </td>
    </tr>
  ));

  useEffect(() => {
    get_list();
  }, []);

  return (
    <div className="content-wrapper">
      <div className="content-header">
        <div className="container-fluid">
          <div className="row mb-2">
            <div className="col-sm-6">
              <h1 className="m-0">Dashboard</h1>
            </div>
            <div className="col-sm-6">
              <ol className="breadcrumb float-sm-right">
                <li className="breadcrumb-item">
                  <span href="#">Home</span>
                </li>
              </ol>
            </div>
          </div>
        </div>
      </div>

      <div className="content">
        <div className="container-fluid">
          <div className="row">
            <div className="col-lg-3 col-6">
              <div className="small-box bg-info">
                <div className="inner">
                  <h3>{donations} $ETH</h3>

                  <p>Donations Received</p>
                </div>
                <div className="icon">
                  <i className="ion ion-cash"></i>
                </div>
              </div>
            </div>
            <div className="col-lg-3 col-6">
              <div className="small-box bg-success">
                <div className="inner">
                  <h3>{funds_approved}</h3>

                  <p>Funds Approved</p>
                </div>
                <div className="icon">
                  <i className="ion ion-checkmark"></i>
                </div>
              </div>
            </div>
            <div className="col-lg-3 col-6">
              <div className="small-box bg-warning">
                <div className="inner">
                  <h3>{total_funds}</h3>

                  <p>Total Funds Request</p>
                </div>
                <div className="icon">
                  <i className="ion ion-person-add"></i>
                </div>
              </div>
            </div>
            <div className="col-lg-3 col-6">
              <div className="small-box bg-danger">
                <div className="inner">
                  <h3>{completed_funds}</h3>

                  <p>Funded Pools</p>
                </div>
                <div className="icon">
                  <i className="ion ion-android-list"></i>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div className="card">
          <div className="card-header border-transparent">
            <h3 className="card-title">List of funds to invest</h3>
          </div>

          <div className="card-body p-0">
            <div className="table-responsive">
              <table className="table m-0">
                <thead>
                  <tr>
                    <th>Pool Name</th>
                    <th>Admin</th>
                    <th>Status</th>
                    <th>Funds Asked</th>
                    <th>Funds Received</th>
                    <th></th>
                  </tr>
                </thead>
                <tbody>{display_list}</tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
