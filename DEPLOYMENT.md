# Deployment checklist

## Local smoke test

Run from the repository root:

```r
shiny::runApp()
```

Then upload a JPEG/PNG image and confirm:
- the image is displayed;
- the general classifier returns Historical/Natural;
- the specific classifier returns one of the 18 locations;
- confidence values are displayed.

## Shiny deployment

A deployment environment must have compatible R, Keras and TensorFlow support.

Typical workflow:

```r
install.packages("rsconnect")
library(rsconnect)

# Configure your account once using the credentials provided by your deployment provider.
# Then deploy:
rsconnect::deployApp()
```

## Important

The HDF5 files in `models/` are runtime dependencies and must be included in the deployed application.

If deployment fails during Keras/TensorFlow initialization, pinning a compatible R/Python/TensorFlow environment is preferable to changing the model files.
