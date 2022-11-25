export const Sidebar = () => {
  return (
    <aside className="main-sidebar sidebar-dark-primary elevation-4">
      <span style={{ cursor: "pointer" }} className="brand-link">
        <img
          src="dist/img/AdminLTELogo.png"
          alt="AdminLTE Logo"
          className="brand-image img-circle elevation-3"
          style={{ opacity: ".8" }}
        />
        <span className="brand-text font-weight-light">Crowd Fund</span>
      </span>
      <div className="sidebar">
        <div className="user-panel mt-3 pb-3 mb-3 d-flex">
          <div className="image">
            <img
              src="dist/img/avatar.jpg"
              className="img-circle elevation-2"
              alt="User"
            />
          </div>

          <div className="info">
            <a href={false} className="d-block">
              Alexander Pierce
            </a>
          </div>
        </div>

        <nav className="mt-2">
          <ul
            className="nav nav-pills nav-sidebar flex-column"
            data-widget="treeview"
            role="menu"
            data-accordion="false"
          >
            <li className="nav-item menu-open">
              <span href="#" className="nav-link active">
                <i className="nav-icon fas fa-tachometer-alt"></i>
                <p>Dashboard</p>
              </span>
            </li>
          </ul>
        </nav>

        <div className="form-inline mt-2">
          <div className="input-group">
            <button
              className="btn btn-block btn-outline-success"
              data-toggle="modal"
              data-target="#modal-default"
            >
              Create Fund Request
            </button>
          </div>
        </div>
      </div>
    </aside>
  );
};
