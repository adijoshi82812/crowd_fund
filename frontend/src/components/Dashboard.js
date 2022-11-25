import { useSelector } from "react-redux";

export const Dashboard = () => {
  const donations = useSelector((state) => state.donations);
  const funds_approved = useSelector((state) => state.approved_pools);
  const total_funds = useSelector((state) => state.total_funds);
  const completed_funds = useSelector((state) => state.completed_pools);

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
                <tbody>
                  <tr>
                    <td>Pool1</td>
                    <td>0x00000000000000000000</td>
                    <td>
                      <span className="badge badge-warning">
                        Pending Approval
                      </span>
                    </td>
                    <td>2 ETH</td>
                    <td>2 ETH</td>
                    <td>
                      <button className="btn btn-block btn-xs btn-success disabled">
                        Invest
                      </button>
                    </td>
                  </tr>

                  <tr>
                    <td>Pool2</td>
                    <td>0x00000000000000000000</td>
                    <td>
                      <span className="badge badge-danger">Pool filled</span>
                    </td>
                    <td>2 ETH</td>
                    <td>2 ETH</td>
                    <td>
                      <button className="btn btn-block btn-xs btn-danger disabled">
                        Invest
                      </button>
                    </td>
                  </tr>

                  <tr>
                    <td>Pool3</td>
                    <td>0x00000000000000000000</td>
                    <td>
                      <span className="badge badge-success">In progress</span>
                    </td>
                    <td>2 ETH</td>
                    <td>2 ETH</td>
                    <td>
                      <button className="btn btn-block btn-xs btn-success">
                        Invest
                      </button>
                    </td>
                  </tr>

                  <tr>
                    <td>Pool4</td>
                    <td>0x00000000000000000000</td>
                    <td>
                      <span className="badge badge-warning">
                        Pending Approval
                      </span>
                    </td>
                    <td>2 ETH</td>
                    <td>2 ETH</td>
                    <td>
                      <button className="btn btn-block btn-xs btn-success disabled">
                        Invest
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
