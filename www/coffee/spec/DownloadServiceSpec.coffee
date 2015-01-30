describe("DownloadService", ->
  it("should be a thing that exists", ->
    expect(DownloadService).toBeDefined()
  )

  it("given an area, stores the area as an instance variable", ->
    area = {}
    service = new DownloadService(area)

    expect(service.area).toBe(area)
  )

  beforeEach( ->
    window.cordova = {
      file: {
        documentsDirectory: "/User/Lieferschein/Documents/"
      }
    }
  )

  describe(".downloadHabitatTiles()", ->
    beforeEach( ->
      @area = new BlueCarbon.Models.Area(id: 12)
      @service = new DownloadService(@area)

      @layer = {
        habitat: "seagrass"
        url: "http://seagrass.com/api/seagrass.json"
      }

      window.FileTransfer = ->
    )

    it("given a habitat layer object, downloads the mbtiles file for the
     habitat and saves to the file system", (done) ->
      FileTransfer:: = { download: (url, name, callback) ->
        callback()
      }

      spy = sinon.spy(FileTransfer::, "download")

      @service.downloadHabitatTiles(@layer, =>
        expect(
          spy.calledWith(@layer.url, "/User/Lieferschein/Documents/12-seagrass.mbtiles")
        ).toBe(true)

        done()
      )
    )

    it("passes an error with the callback if the transfer is
     unsuccessful", (done) ->
      FileTransfer:: = { download: (url, name, cb, errorcb) ->
        errorcb("ERRORORORORRORORO")
      }

      @service.downloadHabitatTiles(@layer, (error) ->
        expect(error).toBe("ERRORORORORRORORO")
        done()
      )
    )
  )

  describe(".downloadHabitats", ->
    beforeEach( ->
      @layers = [{
        habitat: "seagrass"
        url: "http://seagrass.com/api/seagrass.json"
      }, {
        habitat: "mangroves"
        url: "https://mangroves.io/api/mangroves.json"
      }]

      @area = new BlueCarbon.Models.Area(id: 12, mbtiles: @layers)
      @service = new DownloadService(@area)

      window.FileTransfer = ->
      FileTransfer:: = { download: (url, name, callback) -> callback() }
    )

    it("downloads the habitat layers", (done, fail) ->
      @service.downloadHabitats().then(done).catch(fail)
    )
  )

  describe('.downloadBaseLayer', ->
    beforeEach( ->
      @area = new BlueCarbon.Models.Area(id: 12)
      @service = new DownloadService(@area)
    )

    it('downloads the base layer', (done, fail) ->
      saveTilesMethod = (zoom, startcb, cb, errorcb) ->
        cb()
      offlineLayer = {saveTiles: saveTilesMethod}
      sinon.mock(offlineLayer).expects('saveTiles').returns(saveTilesMethod).withArgs(17, null)

      @service.downloadBaseLayer(offlineLayer).then(-> debugger).catch(-> debugger)
    )

  )
)
